using Aromata.Application.Common.Interfaces;
using Aromata.Application.Common.Mappings;
using Aromata.Application.Common.Models;
using Aromata.Domain.Recipes;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Aromata.Application.Recipes.GetRecipes;

internal class GetRecipesQueryHandler(IApplicationDbContext applicationDbContext, IUser user)
    : IRequestHandler<GetRecipesQuery, PaginatedList<RecipeDto>>
{
    public Task<PaginatedList<RecipeDto>> Handle(GetRecipesQuery request, CancellationToken cancellationToken)
    {
        var query = applicationDbContext.Recipes
            .Where(x => x.CreatedBy == user.Id && EF.Functions.Like(x.Title, $"%{request.Title}%"));

        if (request.CategoriesAsList is not null)
        {
            query = query.Where(x => x.Category != null && request.CategoriesAsList.Contains(x.Category));
        }
        
        return query.OrderByColumn(request.SortBy ?? nameof(Recipe.Title), request.Desc)
            .Select(x => x.ToDto())
            .PaginatedListAsync(request.PageNumber, request.PageSize);
    }
}