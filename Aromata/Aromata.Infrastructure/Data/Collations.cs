namespace Aromata.Infrastructure.Data;

public class Collations
{
    public string Code { get; private set; }

    private Collations(string code)
    {
        Code = code;
    }

    public static readonly Collations CaseInsensitive = new("case_insensitive");


    public static implicit operator string(Collations collations) => collations.Code;
}