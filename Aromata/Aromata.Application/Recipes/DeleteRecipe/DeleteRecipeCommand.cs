using Aromata.Application.Common.Security;
using MediatR;

namespace Aromata.Application.Recipes.DeleteRecipe;

[Authorize]
public record DeleteRecipeCommand : IRequest
{
    public Guid Id { get; init; }
}