using FluentValidation;

namespace Aromata.Application.Books.CreateBookCommand;

public class CreateBookCommandValidator : AbstractValidator<CreateBookCommand>
{
    public CreateBookCommandValidator()
    {
        RuleFor(x => x.Title)
            .MaximumLength(150)
            .NotEmpty();

        RuleFor(x => x.Author)
            .MaximumLength(150);
    }
}