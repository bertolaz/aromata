using System.Linq.Expressions;
using Aromata.Application.Books.GetBooks;
using Aromata.Domain.Books;

namespace Aromata.Application.Books;

public static class BookMappings
{
    public static BookDto ToBookDto(this Book book)
    {
        return new BookDto()
        {
            Id = book.Id,
            Title = book.Title,
            Author = book.Author,
            CreatedAt = book.Created
        };
    }

}