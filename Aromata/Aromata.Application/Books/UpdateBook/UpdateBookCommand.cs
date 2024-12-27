using Aromata.Application.Books.GetBooks;
using Aromata.Application.Common.Security;
using MediatR;

namespace Aromata.Application.Books.UpdateBook;

[Authorize]
public record UpdateBookCommand : IRequest<BookDto>
{
    public Guid Id { get; init; }
    public string? Title { get; init; }
    public string? Author { get; init; }
}