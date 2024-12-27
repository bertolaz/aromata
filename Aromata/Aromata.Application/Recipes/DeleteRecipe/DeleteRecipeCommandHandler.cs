using Ardalis.GuardClauses;
using Aromata.Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Aromata.Application.Recipes.DeleteRecipe;

public class DeleteRecipeCommandHandler(IApplicationDbContext dbContext, IUser user)
    : IRequestHandler<DeleteRecipeCommand>
{
    public async Task Handle(DeleteRecipeCommand request, CancellationToken cancellationToken)
    {
        var recipe = await dbContext.Recipes.Where(x => x.CreatedBy == user.Id && x.Id == request.Id)
            .FirstOrDefaultAsync(cancellationToken);
        Guard.Against.NotFound(request.Id, recipe);

        dbContext.Recipes.Remove(recipe);
        await dbContext.SaveChangesAsync(cancellationToken);
    }
}