using Aromata.Application.Common.Models;
using Aromata.Application.Common.Security;

namespace Aromata.Application.Recipes.GetRecipes;

[Authorize]
public record GetRecipesQuery : PaginatedRequest<RecipeDto>
{
    protected override string DefaultOrderBy => $"{nameof(RecipeDto.Title)}";
}