using Aromata.Application.Recipes.GetRecipes;
using MediatR;

namespace Aromata.Application.Recipes.GetRecipe;

public record GetRecipeQuery : IRequest<RecipeDto>
{
    public Guid RecipeId { get; set; }
}