using Aromata.Application.Common.Interfaces;
using MediatR;

namespace Aromata.Application.Users;

public class CreateUserCommandHandler(IIdentityService identityService) : IRequestHandler<CreateUserCommand, string>
{
    public async Task<string> Handle(CreateUserCommand request, CancellationToken cancellationToken)
    {
        var r = await identityService.CreateUserAsync(request.Email!, request.Password!);
        if (!r.Result.Succeeded)
        {
            throw new Exception("Could not create user");
        }
        return r.UserId;
    }
}