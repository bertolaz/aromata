using MediatR;

namespace Aromata.Application.Users;

public record CreateUserCommand : IRequest<string>
{
    public string? Email { get; init; }
    public string? Password { get; init; }
}