using Aromata.Application.Books.GetBooks;
using MediatR;

namespace Aromata.Application.Books.GeBook;

public record GetBookQuery : IRequest<BookDto>
{
    public Guid BookId { get; init; }
}