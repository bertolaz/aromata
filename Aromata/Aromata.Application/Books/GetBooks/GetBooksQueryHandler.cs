using Aromata.Application.Common.Interfaces;
using Aromata.Application.Common.Mappings;
using Aromata.Application.Common.Models;
using Aromata.Domain.Books;
using Gridify;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Aromata.Application.Books.GetBooks;

internal class GetBooksQueryHandler(IApplicationDbContext dbContext, IUser user, ILogger<GetBooksQueryHandler> logger)
    : IRequestHandler<GetBooksQuery, PaginatedList<BookDto>>
{
    public Task<PaginatedList<BookDto>> Handle(GetBooksQuery request, CancellationToken cancellationToken)
    {
        logger.LogInformation("Filter {Filter}", request.Filter);
        var query = dbContext.Books.AsNoTracking()
            .Where(x => x.CreatedBy == user.Id);

        var mapper = new GridifyMapper<Book>()
            .GenerateMappings()
            .AddMap(nameof(Book.Id), x => x.Id, x => x.ToString())
            .RemoveMap(nameof(Book.CreatedBy));

        query = query.ApplyFilteringAndOrdering(request, mapper);

        return query
            .Select(x => x.ToBookDto())
            .PaginatedListAsync(request.Page, request.PageSize);
    }
}