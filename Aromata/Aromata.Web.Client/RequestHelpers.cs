using System.Text;
using System.Text.RegularExpressions;

namespace Aromata.Web.Client;

public partial class RequestHelpers
{
    public static string? ToSafeFilter(string? filter)
        => filter is null ? filter : MyRegex().Replace(filter, "\\$1");

    [GeneratedRegex(@"([(),|\\]|\/i)")]
    private static partial Regex MyRegex();
}

public class FilterBuilder
{
    private string? _stringBuilder;

    public FilterBuilder()
    {
    }
    
    public static FilterBuilder Create() => new();

    public FilterBuilder Eq(string property, string? value, Func<bool>? when = null)
    {
        if (when is not null && !when.Invoke()) return this;
        AppendFilter(property, "=", value);
        return this;
    }

    private void AppendFilter(string property, string @operator, string? value)
    {
        if (!string.IsNullOrEmpty(_stringBuilder))
        {
            _stringBuilder += ", ";
        }

        _stringBuilder += $"{property}{@operator}{RequestHelpers.ToSafeFilter(value)}";
    }

    public FilterBuilder NotEq(string property, string? value, Func<bool>? when = null)
    {
        if (when is not null && !when.Invoke()) return this;
        AppendFilter(property, "!=", value);
        return this;
    }

    public FilterBuilder LessThan(string property, string? value, Func<bool>? when = null)
    {
        if (when is not null && !when.Invoke()) return this;
        AppendFilter(property, "<", value);
        return this;
    }

    public FilterBuilder LessOrEqualThan(string property, string? value, Func<bool>? when = null)
    {
        if (when is not null && !when.Invoke()) return this;
        AppendFilter(property, "<=", value);
        return this;
    }

    public FilterBuilder GreaterThan(string property, string? value, Func<bool>? when = null)
    {
        if (when is not null && !when.Invoke()) return this;
        AppendFilter(property, ">", value);
        return this;
    }

    public FilterBuilder GreaterOrEqualThan(string property, string? value, Func<bool>? when = null)
    {
        if (when is not null && !when.Invoke()) return this;
        AppendFilter(property, ">=", value);
        return this;
    }

    public FilterBuilder Like(string property, string? value, bool caseSensitive = true, Func<bool>? when = null)
    {
        if (when is not null && !when.Invoke()) return this;
        AppendFilter(property, caseSensitive ? "=*" : "#=*", value);
        return this;
    }

    public FilterBuilder NotContains(string property, string? value, Func<bool>? when = null)
    {
        if (when is not null && !when.Invoke()) return this;
        AppendFilter(property, "!*", value);
        return this;
    }

    public FilterBuilder StartsWith(string property, string? value, Func<bool>? when = null)
    {
        if (when is not null && !when.Invoke()) return this;
        AppendFilter(property, "^", value);
        return this;
    }

    public FilterBuilder NotStartsWith(string property, string? value, Func<bool>? when = null)
    {
        if (when is not null && !when.Invoke()) return this;
        AppendFilter(property, "!^", value);
        return this;
    }

    public FilterBuilder In(string property, string[] values, Func<bool>? when = null)
    {
        if (when is not null && !when.Invoke()) return this;
        AppendFilter(property, "#in",  string.Join(';', values));
        return this;
    }

    public string? Build() => _stringBuilder;
}