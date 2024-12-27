using FluentValidation;

namespace Aromata.Application.Books.DeleteBookCommand;

public class DeleteBookCommandValidator : AbstractValidator<DeleteBookCommand>
{
    public DeleteBookCommandValidator()
    {
        RuleFor(x => x.Id).NotEmpty();
    }
}