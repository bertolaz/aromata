using Ardalis.GuardClauses;
using Aromata.Application.Books.GetBooks;
using Aromata.Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Aromata.Application.Books.UpdateBook;

public class UpdateBookCommandHandler(IApplicationDbContext dbContext, IUser user)
    : IRequestHandler<UpdateBookCommand, BookDto>
{
    public async Task<BookDto> Handle(UpdateBookCommand request, CancellationToken cancellationToken)
    {
        var book = await dbContext.Books.FirstOrDefaultAsync(x => x.CreatedBy == user.Id && x.Id == request.Id,
            cancellationToken: cancellationToken);

        Guard.Against.NotFound(request.Id, book);

        book.Title = request.Title;
        book.Author = request.Author;

        await dbContext.SaveChangesAsync(cancellationToken);
        return book.ToBookDto();
    }
}