using Ardalis.GuardClauses;
using Aromata.Application.Common.Interfaces;
using Aromata.Application.Recipes.GetRecipes;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Aromata.Application.Recipes.GetRecipe;

internal class GetRecipeQueryHandler(IApplicationDbContext dbContext, IUser user)
    : IRequestHandler<GetRecipeQuery, RecipeDto>
{
    public async Task<RecipeDto> Handle(GetRecipeQuery request, CancellationToken cancellationToken)
    {
        var recipe = await dbContext.Recipes
            .AsNoTracking()
            .Where(x => x.Id == request.RecipeId && x.CreatedBy == user.Id)
            .FirstOrDefaultAsync(cancellationToken: cancellationToken);

        Guard.Against.NotFound(request.RecipeId, recipe);

        return recipe.ToDto();
    }
}