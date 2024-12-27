using Aromata.Application.Common.Interfaces;
using Aromata.Domain.Books;
using MediatR;

namespace Aromata.Application.Books.CreateBookCommand;

internal class CreateBookCommandHandler(IApplicationDbContext dbContext) : IRequestHandler<CreateBookCommand, Guid>
{
    public async Task<Guid> Handle(CreateBookCommand request, CancellationToken cancellationToken)
    {
        var book = new Book()
        {
            Title = request.Title,
            Author = request.Author,
            Id = Guid.NewGuid()
        };

        await dbContext.Books.AddAsync(book, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);
        return book.Id;
    }
}