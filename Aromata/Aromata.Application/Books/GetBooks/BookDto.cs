namespace Aromata.Application.Books.GetBooks;

public record BookDto
{
    public Guid Id { get; set; }
    public string? Title { get; init; }
    public string? Author { get; init; }
    public DateTimeOffset CreatedAt { get; init; }
}