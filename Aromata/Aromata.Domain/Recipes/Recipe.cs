using Aromata.Domain.Common;

namespace Aromata.Domain.Recipes;

public class Recipe : BaseAuditableEntity
{
    public Guid BookId { get; set; }
    public string? Title { get; set; }
    public int? Page { get; set; }
    public string? Category { get; set; }
    
    
}
