using BookLinqLab.Models;

namespace BookLinqLab.Data;

public static class Queries
{

    public static List<Book> ByAuthor(int authorId) =>
        InMemoryStore.Books.Where(b => b.AuthorId == authorId).ToList();

    public static List<string> SortedTitles() =>
        InMemoryStore.Books.OrderBy(b => b.Title).Select(b => b.Title).ToList();


    public static void PrintGroupedByAuthor()
    {
        var groups = InMemoryStore.Books.GroupBy(b => b.AuthorId);
        foreach (var g in groups)
        {
            var author = InMemoryStore.Authors.FirstOrDefault(a => a.Id == g.Key);
            var authorName = author?.Name ?? "Unknown Author";
            Console.WriteLine($"{authorName}: {g.Count()} book(s)");
        }
    }
    
    public static double AveragePages() =>
        InMemoryStore.Books.Average(b => b.PageCount);

    public static bool AnyOver500() =>
        InMemoryStore.Books.Any(b => b.PageCount > 500);

    public static Book? GetById(int id) =>
        InMemoryStore.Books.FirstOrDefault(b => b.Id == id);

    public static void PrintBooksWithAuthors()
    {
        var joined = InMemoryStore.Books.Join(
            InMemoryStore.Authors,
            book => book.AuthorId,   
            author => author.Id,    
            (book, author) => new { book.Title, Author = author.Name });

        foreach (var x in joined)
            Console.WriteLine($"{x.Title} — {x.Author}");
    }

    public static List<Book> Top3Longest() =>
        InMemoryStore.Books.OrderByDescending(b => b.PageCount).Take(3).ToList();
}