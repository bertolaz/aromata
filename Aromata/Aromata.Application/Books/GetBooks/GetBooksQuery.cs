using Aromata.Application.Common.Models;
using Aromata.Application.Common.Security;
using MediatR;

namespace Aromata.Application.Books.GetBooks;
[Authorize]
public record GetBooksQuery : PaginatedRequest<BookDto>
{
    protected override string DefaultOrderBy => nameof(BookDto.Title);
}