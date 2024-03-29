from __future__ import annotations

from contextlib import suppress

with suppress(ModuleNotFoundError):
    import streamlit as st  # noqa: F401
    from streamlit import (  # noqa: F401
        altair_chart,
        area_chart,
        audio,
        balloons,
        bar_chart,
        bokeh_chart,
        button,
        cache,
        cache_data,
        cache_resource,
        camera_input,
        caption,
        chat_input,
        chat_message,
        checkbox,
        code,
        color_picker,
        column_config,
        columns,
        connection,
        container,
        data_editor,
        dataframe,
        date_input,
        divider,
        download_button,
        echo,
        empty,
        error,
        exception,
        expander,
        file_uploader,
        form,
        form_submit_button,
        graphviz_chart,
        header,
        help,
        image,
        info,
        json,
        latex,
        line_chart,
        link_button,
        markdown,
        metric,
        number_input,
        plotly_chart,
        progress,
        pydeck_chart,
        pyplot,
        radio,
        rerun,
        scatter_chart,
        secrets,
        select_slider,
        selectbox,
        session_state,
        set_page_config,
        sidebar,
        snow,
        spinner,
        status,
        stop,
        subheader,
        success,
        table,
        tabs,
        text,
        text_area,
        text_input,
        time_input,
        title,
        toast,
        toggle,
        vega_lite_chart,
        video,
        write,
    )
