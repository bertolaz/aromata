using Aromata.Domain.Common;

namespace Aromata.Domain.Tags;

public class Tag : BaseAuditableEntity
{
    public string? ObjectType { get; set; }
    public string? Name { get; set; }
}