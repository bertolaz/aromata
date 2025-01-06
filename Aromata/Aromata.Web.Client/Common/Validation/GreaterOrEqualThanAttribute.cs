using System.ComponentModel.DataAnnotations;
using System.Globalization;

namespace Aromata.Web.Client.Common.Validation;

public class GreaterOrEqualThanAttribute(int number, string errorMessage) : ValidationAttribute(errorMessage)
{
    public override bool IsValid(object? value)
    {
        if (value is null) return true;
        return value is int i && i >= number;
    }

    public GreaterOrEqualThanAttribute(int number) : this(number, DefaultErrorMessageString)
    {
    }

    private static string DefaultErrorMessageString => ValidationResources.GreaterOrEqualThanValidationError;


    public override string FormatErrorMessage(string name) =>
        // An error occurred, so we know the value is less than the minimum
        string.Format(CultureInfo.CurrentCulture, ErrorMessageString, name, number);
}