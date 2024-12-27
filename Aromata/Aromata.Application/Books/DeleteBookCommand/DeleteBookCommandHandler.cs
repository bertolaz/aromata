using Ardalis.GuardClauses;
using Aromata.Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Aromata.Application.Books.DeleteBookCommand;

internal class DeleteBookCommandHandler(IApplicationDbContext dbContext, IUser user)
    : IRequestHandler<DeleteBookCommand>
{
    public async Task Handle(DeleteBookCommand request, CancellationToken cancellationToken)
    {
        var book = await dbContext.Books
            .FirstOrDefaultAsync(x => x.Id == request.Id && x.CreatedBy == user.Id,
                cancellationToken: cancellationToken);
        Guard.Against.NotFound(request.Id, book);
        dbContext.Books.Remove(book);
        await dbContext.SaveChangesAsync(cancellationToken);
    }
}