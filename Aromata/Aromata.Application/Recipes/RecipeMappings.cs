using Aromata.Application.Recipes.GetRecipes;
using Aromata.Domain.Recipes;

namespace Aromata.Application.Recipes;

public static class RecipeMappings
{
    public static RecipeDto ToDto(this Recipe recipe)
    {
        return new RecipeDto()
        {
            Title = recipe.Title,
            Category = recipe.Category,
            BookId = recipe.BookId,
            Page = recipe.Page,
            Created = recipe.Created
        };
    }
}