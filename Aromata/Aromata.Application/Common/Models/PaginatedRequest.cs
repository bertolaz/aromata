using Gridify;
using MediatR;

namespace Aromata.Application.Common.Models;

public abstract record PaginatedRequest<TResult> : IGridifyQuery, IRequest<PaginatedList<TResult>>
{
    private int _pageSize = 10;
    private int _page = 1;

    int IGridifyPagination.Page
    {
        get => _page;
        set => _page = value;
    }

    int IGridifyPagination.PageSize
    {
        get => _pageSize;
        set => _pageSize = value;
    }

    public int? Page
    {
        get => _page;
        set => _page = value ?? 1;
    }


    public int? PageSize
    {
        get => _pageSize;
        set => _pageSize = value ?? 10;
    }

    public string? Filter { get; set; }

    private string? _orderBy;

    public string? OrderBy
    {
        get => _orderBy ?? DefaultOrderBy;
        set => _orderBy = value;
    }

    protected abstract string DefaultOrderBy { get; }
}