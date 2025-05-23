using System.Linq.Expressions;
using Aromata.Application.Common.Models;
using Microsoft.EntityFrameworkCore;

namespace Aromata.Application.Common.Mappings;

public static class MappingExtensions
{
    public static Task<PaginatedList<TDestination>> PaginatedListAsync<TDestination>(
        this IQueryable<TDestination> queryable, int? pageNumber, int? pageSize) where TDestination : class
        => PaginatedList<TDestination>.CreateAsync(queryable.AsNoTracking(), pageNumber ?? 1, pageSize ?? 10);

    public static Task<PaginatedList<TDestination>> PaginatedListAsync<TDestination>(
        this IOrderedQueryable<TDestination> queryable, int? pageNumber, int? pageSize) where TDestination : class
        => PaginatedList<TDestination>.CreateAsync(queryable.AsNoTracking(), pageNumber ?? 1, pageSize ?? 10);

    // public static Task<List<TDestination>> ProjectToListAsync<TDestination>(this IQueryable queryable, IConfigurationProvider configuration) where TDestination : class
    //     => queryable.ProjectTo<TDestination>(configuration).AsNoTracking().ToListAsync();

    public static IOrderedQueryable<T> OrderByColumn<T>(this IQueryable<T> source, string columnPath, bool desc)
        => source.OrderByColumnUsing(columnPath, desc ? "OrderByDescending" : "OrderBy");

    public static IOrderedQueryable<T> OrderByColumn<T>(this IQueryable<T> source, string columnPath)
        => source.OrderByColumnUsing(columnPath, "OrderBy");

    public static IOrderedQueryable<T> OrderByColumnDescending<T>(this IQueryable<T> source, string columnPath)
        => source.OrderByColumnUsing(columnPath, "OrderByDescending");

    public static IOrderedQueryable<T> ThenByColumn<T>(this IOrderedQueryable<T> source, string columnPath, bool desc)
        => source.OrderByColumnUsing(columnPath, desc ? "ThenByDescending" : "ThenBy");

    public static IOrderedQueryable<T> ThenByColumn<T>(this IOrderedQueryable<T> source, string columnPath)
        => source.OrderByColumnUsing(columnPath, "ThenBy");

    public static IOrderedQueryable<T> ThenByColumnDescending<T>(this IOrderedQueryable<T> source, string columnPath)
        => source.OrderByColumnUsing(columnPath, "ThenByDescending");

    private static IOrderedQueryable<T> OrderByColumnUsing<T>(this IQueryable<T> source, string columnPath,
        string method)
    {
        var parameter = Expression.Parameter(typeof(T), "item");
        var member = columnPath.Split('.')
            .Aggregate((Expression)parameter, Expression.PropertyOrField);
        var keySelector = Expression.Lambda(member, parameter);
        var methodCall = Expression.Call(typeof(Queryable), method, new[]
                { parameter.Type, member.Type },
            source.Expression, Expression.Quote(keySelector));

        return (IOrderedQueryable<T>)source.Provider.CreateQuery(methodCall);
    }
}