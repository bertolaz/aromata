using Ardalis.GuardClauses;
using Aromata.Application.Common.Interfaces;
using Aromata.Application.Recipes.GetRecipes;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Aromata.Application.Recipes.UpdateRecipe;

internal class UpdateRecipeCommandHandler(IApplicationDbContext dbContext, IUser user)
    : IRequestHandler<UpdateRecipeCommand, RecipeDto>
{
    public async Task<RecipeDto> Handle(UpdateRecipeCommand request, CancellationToken cancellationToken)
    {
        var recipe = await dbContext.Recipes.Where(x => x.CreatedBy == user.Id && x.Id == request.RecipeId)
            .FirstOrDefaultAsync(cancellationToken: cancellationToken);

        Guard.Against.NotFound(request.RecipeId, recipe);
        recipe.Page = request.Page;
        recipe.Category = request.Category;
        recipe.Title = request.Title;
await dbContext.SaveChangesAsync(cancellationToken);
        return recipe.ToDto();
    }
}