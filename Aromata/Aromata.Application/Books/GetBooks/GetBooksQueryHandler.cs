using Aromata.Application.Common.Interfaces;
using Aromata.Application.Common.Mappings;
using Aromata.Application.Common.Models;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Aromata.Application.Books.GetBooks;

internal class GetBooksQueryHandler(IApplicationDbContext dbContext, IUser user)
    : IRequestHandler<GetBooksQuery, PaginatedList<BookDto>>
{
    public Task<PaginatedList<BookDto>> Handle(GetBooksQuery request, CancellationToken cancellationToken)
    {
        var query = dbContext.Books.AsNoTracking()
            .Where(x => x.CreatedBy == user.Id);
        if (!string.IsNullOrEmpty(request.Title))
        {
            query = query.Where(x =>
                EF.Functions.Like(x.Title, $"%{request.Title}%"));
        }

        return query
            .OrderByColumn(request.SortBy ?? "Title", request.Desc)
            .Select(x => x.ToBookDto())
            .PaginatedListAsync(request.PageNumber, request.PageSize);
    }
}