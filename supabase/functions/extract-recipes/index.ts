import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const OPENAI_API_KEY = Deno.env.get('OPENAI_API_KEY')
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? ''
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''

interface Recipe {
  title: string
  page: number
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    })
  }

  try {
    // Verify authentication
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Get the authenticated user
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
      global: {
        headers: { Authorization: authHeader },
      },
    })

    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser()

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Parse the request body
    const { image_url, image_base64, book_id } = await req.json()

    if (!OPENAI_API_KEY) {
      return new Response(
        JSON.stringify({ error: 'OpenAI API key not configured' }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      )
    }

    if (!image_url && !image_base64) {
      return new Response(
        JSON.stringify({ error: 'Either image_url or image_base64 is required' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Prepare image for OpenAI
    let imageDataUrl: string
    if (image_base64) {
      // If already a data URL, use it; otherwise add the prefix
      if (image_base64.startsWith('data:')) {
        imageDataUrl = image_base64
      } else {
        imageDataUrl = `data:image/jpeg;base64,${image_base64}`
      }
    } else if (image_url) {
      // Fetch image and convert to base64
      const imageResponse = await fetch(image_url)
      if (!imageResponse.ok) {
        return new Response(
          JSON.stringify({ error: 'Failed to fetch image from URL' }),
          { status: 400, headers: { 'Content-Type': 'application/json' } }
        )
      }
      const imageBlob = await imageResponse.blob()
      const arrayBuffer = await imageBlob.arrayBuffer()
      const base64 = btoa(String.fromCharCode(...new Uint8Array(arrayBuffer)))
      // Detect MIME type from response or default to jpeg
      const mimeType = imageResponse.headers.get('content-type') || 'image/jpeg'
      imageDataUrl = `data:${mimeType};base64,${base64}`
    } else {
      return new Response(
        JSON.stringify({ error: 'Either image_url or image_base64 is required' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Call OpenAI Vision API
    const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o',
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: `Analyze this image which shows a table of contents or recipe list from a cookbook. Extract all recipes with their page numbers. Return a JSON array of objects with "title" (string) and "page" (number) fields. Only include recipes, not section headers or other content. If a recipe spans multiple pages, use the starting page number. Example format: [{"title": "Chocolate Cake", "page": 45}, {"title": "Apple Pie", "page": 67}]. Return ONLY valid JSON, no other text.`
              },
              {
                type: 'image_url',
                image_url: {
                  url: imageDataUrl
                }
              }
            ]
          }
        ],
        max_tokens: 2000,
      }),
    })

    if (!openaiResponse.ok) {
      const error = await openaiResponse.text()
      console.error('OpenAI API error:', error)
      return new Response(
        JSON.stringify({ error: 'Failed to process image with OpenAI', details: error }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      )
    }

    const openaiData = await openaiResponse.json()
    const extractedText = openaiData.choices[0]?.message?.content

    if (!extractedText) {
      return new Response(
        JSON.stringify({ error: 'No content extracted from image' }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Parse the JSON response from OpenAI
    let recipes: Recipe[]
    try {
      // Clean the response - remove markdown code blocks if present
      const cleanedText = extractedText.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim()
      recipes = JSON.parse(cleanedText)
    } catch (parseError) {
      console.error('Failed to parse OpenAI response:', extractedText)
      return new Response(
        JSON.stringify({ 
          error: 'Failed to parse extracted recipes',
          raw_response: extractedText 
        }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Validate recipes structure
    if (!Array.isArray(recipes)) {
      return new Response(
        JSON.stringify({ error: 'Invalid recipe format: expected array' }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Validate each recipe
    const validRecipes = recipes.filter((recipe: any) => {
      return (
        typeof recipe === 'object' &&
        typeof recipe.title === 'string' &&
        typeof recipe.page === 'number' &&
        recipe.title.trim().length > 0 &&
        recipe.page > 0
      )
    })

    // Return the extracted recipes
    return new Response(
      JSON.stringify({ 
        recipes: validRecipes,
        count: validRecipes.length 
      }),
      {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  }
})

