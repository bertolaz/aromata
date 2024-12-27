using Aromata.Domain.Common;

namespace Aromata.Domain.Books;

public class Book : BaseAuditableEntity
{
    public string? Title { get; set; }
    public string? Author { get; set; }
    
}