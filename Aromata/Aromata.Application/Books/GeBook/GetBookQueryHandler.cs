using Ardalis.GuardClauses;
using Aromata.Application.Books.GetBooks;
using Aromata.Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Aromata.Application.Books.GeBook;

public class GetBookQueryHandler(IApplicationDbContext dbContext, IUser user) : IRequestHandler<GetBookQuery, BookDto>
{
    public async Task<BookDto> Handle(GetBookQuery request, CancellationToken cancellationToken)
    {
        var book = await dbContext.Books.AsNoTracking()
            .Where(x => x.CreatedBy == user.Id && x.Id == request.BookId)
            .Select(x => x.ToBookDto()).FirstOrDefaultAsync(cancellationToken);

        Guard.Against.NotFound(request.BookId, book);

        return book;
    }
}