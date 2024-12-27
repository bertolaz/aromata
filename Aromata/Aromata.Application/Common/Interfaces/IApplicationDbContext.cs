using Aromata.Domain.Books;
using Aromata.Domain.Recipes;
using Microsoft.EntityFrameworkCore;

namespace Aromata.Application.Common.Interfaces;

public interface IApplicationDbContext
{
    DbSet<Book> Books { get; }
    DbSet<Recipe> Recipes { get; set; }
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}