using Aromata.Application.Common.Security;
using MediatR;
namespace Aromata.Application.Books.CreateBookCommand;

[Authorize]
public record CreateBookCommand : IRequest<Guid>
{
    public required string Title { get; init; }
    public required string Author { get; init; }
}