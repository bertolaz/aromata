using Aromata.Application.Recipes.CreateRecipe;
using Aromata.Application.Recipes.DeleteRecipe;
using Aromata.Application.Recipes.GetRecipe;
using Aromata.Application.Recipes.GetRecipes;
using Aromata.Application.Recipes.UpdateRecipe;
using Aromata.Web.Infrastructure;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace Aromata.Web.Endpoints;

public class Recipes : EndpointGroupBase
{
    public override void Map(WebApplication app)
    {
        app.MapGroup(this)
            .MapGet(GetRecipes, "/")
            .MapGet(GetRecipe, "/{recipeId:guid}")
            .MapPost(CreateRecipe, "/")
            .MapDelete(DeleteRecipe, "/{recipeId:guid}")
            .MapPut(UpdateRecipe, "/{recipeId:guid}");
    }

    private static async Task<IResult> GetRecipes([AsParameters] GetRecipesQuery query, [FromServices] ISender sender)
    {
        return Results.Ok(await sender.Send(query));
    }

    private static async Task<IResult> GetRecipe([FromRoute] Guid recipeId, [FromServices] ISender sender)
    {
        return Results.Ok(await sender.Send(new GetRecipeQuery()
        {
            RecipeId = recipeId
        }));
    }

    private static async Task<IResult> CreateRecipe([FromBody] CreateRecipeCommand command,
        [FromServices] ISender sender)
    {
        var recipeId = await sender.Send(command);
        return Results.Created($"/api/recipes/{recipeId}", recipeId);
    }

    private static async Task<IResult> DeleteRecipe([FromRoute] Guid recipeId, [FromServices] ISender sender)
    {
        await sender.Send(new DeleteRecipeCommand()
        {
            Id = recipeId
        });
        return Results.NoContent();
    }

    private static async Task<IResult> UpdateRecipe([FromRoute] Guid recipeId, [FromBody] UpdateRecipeCommand command,
        [FromServices] ISender sender)
    {
        return Results.Ok(await sender.Send(command));
    }
}