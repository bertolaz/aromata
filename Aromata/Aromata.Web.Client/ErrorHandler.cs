using MudBlazor;

namespace Aromata.Web.Client;

public class ErrorHandler(ISnackbar snackbar, ILogger<ErrorHandler> logger)
{
    public void ProcessError(Exception e)
    {
        snackbar.Add("An error occurred", Severity.Error);
        logger.LogError(e, "An unhandled error occurred: {ErrorMessage}", e.Message);
    }
}