using BookLinqLab.Data;
using BookLinqLab.Services;

Console.WriteLine("== Sorted titles ==");
Queries.SortedTitles().ForEach(Console.WriteLine);

Console.WriteLine("\n== Grouped by author ==");
Queries.PrintGroupedByAuthor();

Console.WriteLine($"\nAverage pages: {Queries.AveragePages():F1}");
Console.WriteLine($"Any book over 500 pages? {Queries.AnyOver500()}");

Console.WriteLine("\n== Books + Authors (join) ==");
Queries.PrintBooksWithAuthors();

Console.WriteLine("\n== Top 3 longest ==");
Queries.Top3Longest().ForEach(b => Console.WriteLine($"{b.Title} ({b.PageCount}p)"));

Console.WriteLine("\n== Service: create + fetch ==");
IBookService service = new BookService();  
var created = service.Create(new BookLinqLab.Models.Book
{
    Title = "Test Book", Year = 2024, PageCount = 200, AuthorId = 1
});
Console.WriteLine($"Created Id={created.Id}, now {service.GetAll().Count()} books total");