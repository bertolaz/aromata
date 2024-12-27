using Aromata.Application.Recipes.GetRecipes;
using MediatR;

namespace Aromata.Application.Recipes.UpdateRecipe;

public record UpdateRecipeCommand : IRequest<RecipeDto>
{
    public int? Page { get; init;  }
    public Guid RecipeId { get; init; }
    public string? Title { get; set; }
    public string? Category { get; set; }
}