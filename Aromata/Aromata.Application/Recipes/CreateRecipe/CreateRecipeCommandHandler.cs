using Ardalis.GuardClauses;
using Aromata.Application.Common.Interfaces;
using Aromata.Domain.Recipes;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Aromata.Application.Recipes.CreateRecipe;

public class CreateRecipeCommandHandler(IApplicationDbContext dbContext, IUser user)
    : IRequestHandler<CreateRecipeCommand, Guid>
{
    public async Task<Guid> Handle(CreateRecipeCommand request, CancellationToken cancellationToken)
    {
        var bookId = await dbContext.Books.Where(x => x.Id == request.BookId && x.CreatedBy == user.Id)
            .Select(x => x.Id)
            .FirstOrDefaultAsync(cancellationToken: cancellationToken);

        Guard.Against.Default(bookId,
            parameterName: nameof(request.BookId), $"Book with id {request.BookId} not found");

        var recipe = new Recipe()
        {
            Id = Guid.NewGuid(),
            BookId = bookId,
            Title = request.Title,
            Category = request.Category
        };
        await dbContext.Recipes.AddAsync(recipe, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);

        return recipe.Id;
    }
}