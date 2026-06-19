using BookLinqLab.Models;

namespace BookLinqLab.Data;

public static class InMemoryStore
{
    public static List<Author> Authors { get; } = new();
    public static List<Book> Books { get; } = new();
    public static List<Tag> Tags { get; } = new();
    public static List<BookTag> BookTags { get; } = new();

    static InMemoryStore()
    {
        Authors.AddRange(new[]
        {
            new Author { Id = 1, Name = "George Orwell" },
            new Author { Id = 2, Name = "J.R.R. Tolkien" },
            new Author { Id = 3, Name = "Yuval Noah Harari" },
        });

        Books.AddRange(new[]
        {
            new Book { Id = 1, Title = "Animal Farm",              Year = 1945, PageCount = 112, AuthorId = 1 },
            new Book { Id = 2, Title = "1984",                     Year = 1949, PageCount = 328, AuthorId = 1 },
            new Book { Id = 3, Title = "The Hobbit",               Year = 1937, PageCount = 310, AuthorId = 2 },
            new Book { Id = 4, Title = "The Fellowship of the Ring", Year = 1954, PageCount = 531, AuthorId = 2 },
            new Book { Id = 5, Title = "The Two Towers",           Year = 1954, PageCount = 447, AuthorId = 2 },
            new Book { Id = 6, Title = "The Return of the King",   Year = 1955, PageCount = 624, AuthorId = 2 },
            new Book { Id = 7, Title = "Sapiens",                  Year = 2011, PageCount = 443, AuthorId = 3 },
            new Book { Id = 8, Title = "Homo Deus",                Year = 2015, PageCount = 528, AuthorId = 3 },
        });

        Tags.AddRange(new[]
        {
            new Tag { Id = 1, Name = "Classic" },
            new Tag { Id = 2, Name = "Fantasy" },
            new Tag { Id = 3, Name = "Dystopian" },
            new Tag { Id = 4, Name = "Non-Fiction" },
        });

        BookTags.AddRange(new[]
        {
            new BookTag { BookId = 1, TagId = 1 }, 
            new BookTag { BookId = 1, TagId = 3 }, 
            new BookTag { BookId = 2, TagId = 3 }, 
            new BookTag { BookId = 3, TagId = 2 },
            new BookTag { BookId = 4, TagId = 2 },
            new BookTag { BookId = 7, TagId = 4 }, 
        });
    }
}