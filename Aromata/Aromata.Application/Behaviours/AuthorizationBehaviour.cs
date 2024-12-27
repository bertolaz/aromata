using System.Reflection;
using Aromata.Application.Common.Exceptions;
using Aromata.Application.Common.Interfaces;
using Aromata.Application.Common.Security;
using MediatR;

namespace Aromata.Application.Behaviours;

public class AuthorizationBehaviour<TRequest, TResponse>(
    IUser user,
    IIdentityService identityService) : IPipelineBehavior<TRequest, TResponse>
    where TRequest : notnull
{
    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        var authorizeAttributes = request.GetType().GetCustomAttributes<AuthorizeAttribute>();

        var attributes = authorizeAttributes as AuthorizeAttribute[] ?? authorizeAttributes.ToArray();
        if (attributes.Any())
        {
            // Must be authenticated user
            if (user.Id == null)
            {
                throw new UnauthorizedAccessException();
            }

            // Role-based authorization
            var authorizeAttributesWithRoles = attributes.Where(a => !string.IsNullOrWhiteSpace(a.Roles));

            var attributesWithRoles = authorizeAttributesWithRoles as AuthorizeAttribute[] ?? authorizeAttributesWithRoles.ToArray();
            if (attributesWithRoles.Any())
            {
                var authorized = false;

                foreach (var roles in attributesWithRoles.Select(a => a.Roles?.Split(',') ?? []))
                {
                    foreach (var role in roles)
                    {
                        var isInRole = await identityService.IsInRoleAsync(user.Id, role.Trim());
                        if (isInRole)
                        {
                            authorized = true;
                            break;
                        }
                    }
                }

                // Must be a member of at least one role in roles
                if (!authorized)
                {
                    throw new ForbiddenAccessException();
                }
            }

            // Policy-based authorization
            var authorizeAttributesWithPolicies = attributes.Where(a => !string.IsNullOrWhiteSpace(a.Policy));
            var attributesWithPolicies = authorizeAttributesWithPolicies as AuthorizeAttribute[] ?? authorizeAttributesWithPolicies.ToArray();
            if (attributesWithPolicies.Any())
            {
                foreach (var policy in attributesWithPolicies.Select(a => a.Policy))
                {
                    var authorized = policy is not null && await identityService.AuthorizeAsync(user.Id, policy);

                    if (!authorized)
                    {
                        throw new ForbiddenAccessException();
                    }
                }
            }
        }

        // User is authorized / authorization not required
        return await next();
    }
}