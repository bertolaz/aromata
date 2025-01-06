namespace Aromata.Web.Client.Common;

public record PaginatedResult<T>
{
    public List<T> Items { get; init; } = [];
    public int PageNumber { get; init;}
    public int TotalPages { get; init;}
    public int TotalCount { get; init;}
    public int PageSize { get; init;}
    
    public bool HasPreviousPage => PageNumber > 1;

    public bool HasNextPage => PageNumber < TotalPages;
}