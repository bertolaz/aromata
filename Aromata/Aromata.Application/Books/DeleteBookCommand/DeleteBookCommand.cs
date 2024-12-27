using Aromata.Application.Common.Security;
using MediatR;

namespace Aromata.Application.Books.DeleteBookCommand;

[Authorize]
public record DeleteBookCommand : IRequest
{
    public Guid Id { get; init; }
}