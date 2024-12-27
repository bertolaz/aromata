using FluentValidation;

namespace Aromata.Application.Recipes.CreateRecipe;

public class CreateRecipeCommandValidator : AbstractValidator<CreateRecipeCommand>
{
    public CreateRecipeCommandValidator()
    {
        RuleFor(x => x.Page)
            .GreaterThan(0)
            .Unless(x => x.Page is null);

        RuleFor(x => x.Title)
            .NotEmpty()
            .MaximumLength(150);

        RuleFor(x => x.BookId)
            .NotEmpty();

    }
}