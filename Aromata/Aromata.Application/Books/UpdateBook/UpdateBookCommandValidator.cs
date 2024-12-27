using FluentValidation;

namespace Aromata.Application.Books.UpdateBook;

public class UpdateBookCommandValidator : AbstractValidator<UpdateBookCommand>
{
    public UpdateBookCommandValidator()
    {
        RuleFor(x => x.Title)
            .MaximumLength(150)
            .NotEmpty();

        RuleFor(x => x.Author)
            .MaximumLength(150);
    }
}