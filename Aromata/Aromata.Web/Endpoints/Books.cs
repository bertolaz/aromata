using Aromata.Application.Books.CreateBookCommand;
using Aromata.Application.Books.DeleteBookCommand;
using Aromata.Application.Books.GeBook;
using Aromata.Application.Books.GetBooks;
using Aromata.Application.Books.UpdateBook;
using Aromata.Web.Infrastructure;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace Aromata.Web.Endpoints;

public class Books : EndpointGroupBase
{
    public override void Map(WebApplication app)
    {
        var group = app.MapGroup(this);
        group.MapGet("/", GetBooks);
        group.MapGet("/{bookId:guid}", GetBook);
        group.MapPost("/", CreateBook);
        group.MapDelete("/{bookId:guid}", DeleteBook);
        group.MapPut("/{bookId:guid}", UpdateBook);
    }

    private static async Task<IResult> GetBooks([AsParameters] GetBooksQuery query, [FromServices] ISender sender)
    {
        var res = await sender.Send(query);
        return Results.Ok(res);
    }

    private static async Task<IResult> GetBook([FromRoute] Guid bookId, [FromServices] ISender sender)
    {
        var res = await sender.Send(new GetBookQuery()
        {
            BookId = bookId
        });
        return Results.Ok(res);
    }

    private static async Task<IResult> CreateBook([FromBody] CreateBookCommand command, [FromServices] ISender sender)
    {
        var bookId = await sender.Send(command);
        return Results.Created($"/api/books/{bookId}", bookId);
    }

    private static async Task<IResult> DeleteBook([FromRoute] Guid bookId, [FromServices] ISender sender)
    {
        await sender.Send(new DeleteBookCommand()
        {
            Id = bookId
        });
        return Results.NoContent();
    }

    private static async Task<IResult> UpdateBook([FromRoute] Guid bookId, [FromBody] UpdateBookCommand command,
        [FromServices] ISender sender)
    {
        return Results.Ok(await sender.Send(command));
    }
}