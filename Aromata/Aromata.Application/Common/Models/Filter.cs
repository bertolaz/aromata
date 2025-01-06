namespace Aromata.Application.Common.Models;

public class Filter
{
    public required string PropertyName { get; set; }
    public required string Operator { get; set; }
    public required object Value { get; set; }
}