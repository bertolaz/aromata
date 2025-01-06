using Aromata.Application.Common.Interfaces;
using Aromata.Application.Common.Mappings;
using Aromata.Application.Common.Models;
using Aromata.Domain.Recipes;
using Gridify;
using MediatR;

namespace Aromata.Application.Recipes.GetRecipes;

internal class GetRecipesQueryHandler(IApplicationDbContext applicationDbContext, IUser user)
    : IRequestHandler<GetRecipesQuery, PaginatedList<RecipeDto>>
{
    public Task<PaginatedList<RecipeDto>> Handle(GetRecipesQuery request, CancellationToken cancellationToken)
    {
        var query = applicationDbContext.Recipes
            .Where(x => x.CreatedBy == user.Id);

        var mapper = new GridifyMapper<Recipe>()
            .GenerateMappings()
            .RemoveMap(nameof(Recipe.CreatedBy));

        query = query.ApplyFilteringAndOrdering(request, mapper);

        return query
            .Select(x => x.ToDto())
            .PaginatedListAsync(request.Page, request.PageSize);
    }
}