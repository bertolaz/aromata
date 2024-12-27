using Aromata.Application.Common.Security;
using MediatR;

namespace Aromata.Application.Recipes.CreateRecipe;
[Authorize]
public record CreateRecipeCommand : IRequest<Guid>
{
    public int? Page { get; init;  }
    public Guid BookId { get; init; }
    public string? Title { get; set; }
    
    public string? Category { get; set; }

}