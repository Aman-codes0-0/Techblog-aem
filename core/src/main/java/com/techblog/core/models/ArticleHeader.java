package com.techblog.core.models;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Calendar;
import java.util.Locale;

import org.apache.sling.api.resource.Resource;
import org.apache.sling.models.annotations.DefaultInjectionStrategy;
import org.apache.sling.models.annotations.Model;
import org.apache.sling.models.annotations.injectorspecific.ValueMapValue;

/**
 * Sling Model for the Article Header component.
 * Reads dialog values from the JCR and computes derived fields:
 * estimated read time (based on word count) and a formatted publish date.
 */
@Model(adaptables = Resource.class, defaultInjectionStrategy = DefaultInjectionStrategy.OPTIONAL)
public class ArticleHeader {

    private static final int WORDS_PER_MINUTE = 200;

    // DateTimeFormatter is thread-safe and immutable — safe to use as a static constant.
    // Locale.ENGLISH ensures month names (e.g. "Oct") are always in English,
    // regardless of the AEM server's OS locale.
    private static final DateTimeFormatter DATE_FORMAT =
            DateTimeFormatter.ofPattern("dd MMM yyyy", Locale.ENGLISH);

    @ValueMapValue
    private String title;

    @ValueMapValue
    private String author;

    @ValueMapValue
    private Calendar publishDate;

    @ValueMapValue
    private String articleText;

    public String getTitle() {
        return title != null ? title : "Untitled Article";
    }

    public String getAuthor() {
        return author != null ? author : "Unknown";
    }

    public String getArticleText() {
        return articleText;
    }

    public String getFormattedDate() {
        if (publishDate == null) {
            return "";
        }
        LocalDate date = publishDate.toInstant()
                .atZone(ZoneId.systemDefault())
                .toLocalDate();
        return date.format(DATE_FORMAT);
    }

    public String getReadTime() {
        if (articleText == null || articleText.trim().isEmpty()) {
            return "1 min read";
        }
        int words = articleText.trim().split("\\s+").length;
        int minutes = Math.max(1, (int) Math.ceil((double) words / WORDS_PER_MINUTE));
        return minutes + " min read";
    }
}
