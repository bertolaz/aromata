using Aromata.Application.Common.Models;
using Aromata.Application.Common.Security;
using MediatR;

namespace Aromata.Application.Books.GetBooks;
[Authorize]
public record GetBooksQuery : IRequest<PaginatedList<BookDto>>
{
    public int PageNumber { get; init; } = 1;
    public int PageSize { get; init; } = 10;
    
    public string? Title { get; init; }
    
    public string? SortBy { get; init; }
    
    public bool Desc { get; init; }
}