using Aromata.Application.Common.Models;
using Aromata.Application.Common.Security;
using MediatR;

namespace Aromata.Application.Recipes.GetRecipes;
[Authorize]
public record GetRecipesQuery : IRequest<PaginatedList<RecipeDto>>
{
    public string? BookIds { get; set; }

    public List<string>? BookIdsAsList => BookIds?.Split(',').ToList();
    public string? Title { get; set; }
    public string? Categories { get; set; }

    public List<string>? CategoriesAsList => Categories?.Split(',').ToList();

    public int PageNumber { get; set; } = 1;

    public int PageSize { get; set; } = 10;
    
    public bool Desc { get; set; }
    
    public string? SortBy { get; set; }


}