-- ============================================================
--  CORONA LIGHT MANAGER PRO v2.0
--  3ds Max 2024 + Corona Renderer 12
--  Har bir chiroqni alohida boshqarish imkoniyati
-- ============================================================

macroScript CoronaLightManagerPro
    category:"Corona Tools"
    tooltip:"Corona Light Manager Pro - Chiroqlarni boshqarish"
    buttonText:"Light Manager"
    icon:#("Standard",24)
(

-- ============================================================
-- GLOBAL O'ZGARUVCHILAR
-- ============================================================
global CLM_Dialog = undefined
global CLM_LightsList = #()
global CLM_SoloedLight = undefined

-- ============================================================
-- ASOSIY ROLLOUT
-- ============================================================
rollout CLM_Rollout "Corona Light Manager Pro v2.0" width:480 height:820 (

    -- ========== YUQORI QISM ==========
    label lbl_title "CORONA LIGHT MANAGER PRO" align:#center height:20
    label lbl_ver "v2.0 | 3ds Max 2024 | Corona 12" align:#center
    label lbl_line1 "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" align:#center

    -- ========== CHIROQLAR RO'YXATI ==========
    group "Sahnidagi Corona Chiroqlar" (
        multilistbox mlb_lights "Chiroqlar:" height:12 width:440
        label lbl_count "Jami: 0 ta chiroq" align:#left
        button btn_refresh "Yangilash" width:140 height:26 across:3
        button btn_select_all_list "Hammasini Belgilash" width:140 height:26
        button btn_select_none "Belgilashni Olib Tashlash" width:140 height:26
    )

    label lbl_line2 "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" align:#center

    -- ========== ALOHIDA CHIROQ BOSHQARUVI ==========
    group "Tanlangan Chiroq(lar)ni Boshqarish" (
        -- Yoqish / O'chirish
        label lbl_onoff "Holat:" align:#left
        button btn_on       "YOQISH"         width:140 height:30 across:3
        button btn_off      "O'CHIRISH"      width:140 height:30
        button btn_toggle   "TOGGLE"         width:140 height:30

        label lbl_sep_a " " align:#left

        -- Solo rejim
        label lbl_solo "Solo rejim (faqat tanlanganni ko'rsatish):" align:#left
        button btn_solo     "SOLO ON"   width:210 height:30 across:2
        button btn_unsolo   "SOLO OFF (barchasini qaytarish)" width:210 height:30

        label lbl_sep_b " " align:#left

        -- Intensivlik
        label lbl_int "Intensivlik (Multiplier):" align:#left
        spinner spn_intensity "Qiymati:" range:[0, 100000, 1000] type:#float scale:5 width:300 across:2
        button btn_apply_int "Qo'llash" width:120 height:24

        label lbl_sep_c " " align:#left

        -- Rang
        label lbl_clr "Chiroq rangi:" align:#left
        colorpicker cp_color "Rang:" color:(color 255 238 200) width:180 across:2
        button btn_apply_color "Rangni Qo'llash" width:180 height:24

        label lbl_sep_d " " align:#left

        -- Kelvin
        label lbl_kelvin "Rang harorati (Kelvin):" align:#left
        checkbox chk_kelvin "Kelvin rejimini yoqish" checked:false
        spinner spn_kelvin "Kelvin:" range:[1000, 15000, 4500] type:#integer scale:50 width:300 across:2
        button btn_apply_kelvin "Kelvinni Qo'llash" width:120 height:24

        label lbl_sep_e " " align:#left

        -- Radius / Size
        label lbl_size "Chiroq o'lchami (Size):" align:#left
        spinner spn_size "O'lchami:" range:[0, 5000, 50] type:#float scale:1 width:300 across:2
        button btn_apply_size "O'lchamni Qo'llash" width:120 height:24

        label lbl_sep_f " " align:#left

        -- Include / Exclude
        checkbox chk_shadows "Soyalar (Shadows)" checked:true across:2
        button btn_apply_shadows "Qo'llash" width:120 height:24
    )

    label lbl_line3 "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" align:#center

    -- ========== GLOBAL BOSHQARUV ==========
    group "Barcha Chiroqlarga (Global)" (
        button btn_all_on     "BARCHASINI YOQISH"     width:210 height:30 across:2
        button btn_all_off    "BARCHASINI O'CHIRISH"  width:210 height:30
        label lbl_g1 " "
        label lbl_global_int "Global Multiplier:" align:#left
        spinner spn_global_int "Qiymat:" range:[0, 100000, 1000] type:#float scale:10 width:300 across:2
        button btn_global_int "Barchasiga Qo'llash" width:120 height:24
        label lbl_g2 " "
        label lbl_global_clr "Global Rang:" align:#left
        colorpicker cp_global_color "Rang:" color:(color 255 255 255) width:180 across:2
        button btn_global_color "Barchasiga Rang" width:180 height:24
        label lbl_g3 " "
        label lbl_global_kelvin "Global Kelvin:" align:#left
        spinner spn_global_kelvin "K:" range:[1000, 15000, 5000] type:#integer scale:100 width:300 across:2
        button btn_global_kelvin "Barchasiga Kelvin" width:120 height:24
    )

    label lbl_line4 "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" align:#center

    -- ========== SAHNADA TANLASH ==========
    group "Sahnada" (
        button btn_scene_select "Sahnada Tanlash" width:210 height:28 across:2
        button btn_scene_focus  "Tanlanganga Zoom" width:210 height:28
    )

    -- Status bar
    label lbl_status "Tayyor. Ro'yxatni yangilang." align:#center

    -- ============================================================
    -- FUNKSIYALAR
    -- ============================================================

    -- Barcha Corona chiroqlarini topish
    fn getCoronaLights = (
        local arr = #()
        for obj in objects where (classof obj == CoronaLight) do (
            append arr obj
        )
        arr
    )

    -- Tanlangan indekslar
    fn getSelectedLights = (
        local sel = mlb_lights.selection
        local result = #()
        for i in sel where (i > 0 and i <= CLM_LightsList.count) do (
            append result CLM_LightsList[i]
        )
        result
    )

    -- Ro'yxatni yangilash
    fn refreshList = (
        CLM_LightsList = getCoronaLights()
        local names = #()
        for lt in CLM_LightsList do (
            local state = if lt.enabled then "[ON]  " else "[OFF] "
            local info = state + lt.name + "  |  Int:" + (lt.intensity as string)
            append names info
        )
        mlb_lights.items = names
        lbl_count.text = ("Jami: " + (CLM_LightsList.count as string) + " ta chiroq")
    )

    -- Bitta chiroq parametrlarini ko'rsatish
    fn showLightParams lt = (
        spn_intensity.value = lt.intensity
        cp_color.color = lt.color
        spn_kelvin.value = lt.colorTemperature
        chk_kelvin.checked = lt.useColorTemperature
        chk_shadows.checked = lt.castShadows
        lbl_status.text = ("Tanlandi: " + lt.name)
    )

    -- ============================================================
    -- EVENTLAR
    -- ============================================================

    -- OYNA OCHILGANDA
    on CLM_Rollout open do (
        refreshList()
    )

    -- YANGILASH
    on btn_refresh pressed do (
        refreshList()
        lbl_status.text = "Ro'yxat yangilandi."
    )

    -- RO'YXATDAN TANLASH
    on mlb_lights selectionEnd do (
        local sel = getSelectedLights()
        if sel.count == 1 do showLightParams sel[1]
        if sel.count > 1 do (
            lbl_status.text = (sel.count as string) + " ta chiroq tanlandi."
        )
    )

    -- HAMMASINI BELGILASH
    on btn_select_all_list pressed do (
        local allIdx = #{1..CLM_LightsList.count}
        mlb_lights.selection = allIdx
        lbl_status.text = "Barcha chiroqlar belgilandi."
    )

    -- BELGILASHNI OLIB TASHLASH
    on btn_select_none pressed do (
        mlb_lights.selection = #{}
        lbl_status.text = "Belgilash olib tashlandi."
    )

    -- ======= YOQISH / O'CHIRISH =======

    on btn_on pressed do (
        local sel = getSelectedLights()
        for lt in sel do lt.enabled = true
        refreshList()
        lbl_status.text = (sel.count as string) + " ta chiroq YOQILDI."
    )

    on btn_off pressed do (
        local sel = getSelectedLights()
        for lt in sel do lt.enabled = false
        refreshList()
        lbl_status.text = (sel.count as string) + " ta chiroq O'CHIRILDI."
    )

    on btn_toggle pressed do (
        local sel = getSelectedLights()
        for lt in sel do lt.enabled = not lt.enabled
        refreshList()
        lbl_status.text = (sel.count as string) + " ta chiroq TOGGLE qilindi."
    )

    -- ======= SOLO REJIM =======

    on btn_solo pressed do (
        local sel = getSelectedLights()
        if sel.count > 0 do (
            -- Barchasini o'chirish, faqat tanlanganlarni yoqish
            for lt in CLM_LightsList do lt.enabled = false
            for lt in sel do lt.enabled = true
            CLM_SoloedLight = sel
            refreshList()
            lbl_status.text = "SOLO rejim: faqat tanlangan chiroqlar yonmoqda."
        )
    )

    on btn_unsolo pressed do (
        -- Barchasini qaytarish (yoqish)
        for lt in CLM_LightsList do lt.enabled = true
        CLM_SoloedLight = undefined
        refreshList()
        lbl_status.text = "SOLO OFF: barcha chiroqlar yoqildi."
    )

    -- ======= INTENSIVLIK =======

    on btn_apply_int pressed do (
        local sel = getSelectedLights()
        for lt in sel do lt.intensity = spn_intensity.value
        refreshList()
        lbl_status.text = (sel.count as string) + " ta chiroqqa intensity = " + (spn_intensity.value as string) + " qo'llandi."
    )

    -- ======= RANG =======

    on btn_apply_color pressed do (
        local sel = getSelectedLights()
        for lt in sel do (
            lt.color = cp_color.color
            lt.useColorTemperature = false
        )
        refreshList()
        lbl_status.text = (sel.count as string) + " ta chiroqqa rang qo'llandi."
    )

    -- ======= KELVIN =======

    on chk_kelvin changed state do (
        local sel = getSelectedLights()
        for lt in sel do lt.useColorTemperature = state
    )

    on btn_apply_kelvin pressed do (
        local sel = getSelectedLights()
        for lt in sel do (
            lt.colorTemperature = spn_kelvin.value
            lt.useColorTemperature = true
        )
        chk_kelvin.checked = true
        refreshList()
        lbl_status.text = (sel.count as string) + " ta chiroqqa " + (spn_kelvin.value as string) + "K qo'llandi."
    )

    -- ======= SIZE =======

    on btn_apply_size pressed do (
        local sel = getSelectedLights()
        for lt in sel do (
            try (lt.size = spn_size.value) catch()
            try (lt.width = spn_size.value; lt.length = spn_size.value) catch()
        )
        lbl_status.text = (sel.count as string) + " ta chiroq o'lchami o'zgartirildi."
    )

    -- ======= SHADOWS =======

    on btn_apply_shadows pressed do (
        local sel = getSelectedLights()
        for lt in sel do lt.castShadows = chk_shadows.checked
        lbl_status.text = (sel.count as string) + " ta chiroqqa shadows = " + (chk_shadows.checked as string)
    )

    -- ======= GLOBAL =======

    on btn_all_on pressed do (
        for lt in CLM_LightsList do lt.enabled = true
        refreshList()
        lbl_status.text = "BARCHA chiroqlar YOQILDI."
    )

    on btn_all_off pressed do (
        for lt in CLM_LightsList do lt.enabled = false
        refreshList()
        lbl_status.text = "BARCHA chiroqlar O'CHIRILDI."
    )

    on btn_global_int pressed do (
        for lt in CLM_LightsList do lt.intensity = spn_global_int.value
        refreshList()
        lbl_status.text = "Barcha chiroqlarga intensity = " + (spn_global_int.value as string)
    )

    on btn_global_color pressed do (
        for lt in CLM_LightsList do (
            lt.color = cp_global_color.color
            lt.useColorTemperature = false
        )
        refreshList()
        lbl_status.text = "Barcha chiroqlarga rang qo'llandi."
    )

    on btn_global_kelvin pressed do (
        for lt in CLM_LightsList do (
            lt.colorTemperature = spn_global_kelvin.value
            lt.useColorTemperature = true
        )
        refreshList()
        lbl_status.text = "Barcha chiroqlarga " + (spn_global_kelvin.value as string) + "K qo'llandi."
    )

    -- ======= SAHNADA TANLASH =======

    on btn_scene_select pressed do (
        local sel = getSelectedLights()
        if sel.count > 0 do (
            select sel[1]
            for i = 2 to sel.count do selectMore sel[i]
            lbl_status.text = (sel.count as string) + " ta chiroq sahnada tanlandi."
        )
    )

    on btn_scene_focus pressed do (
        local sel = getSelectedLights()
        if sel.count > 0 do (
            select sel[1]
            for i = 2 to sel.count do selectMore sel[i]
            max zoomext sel
            lbl_status.text = "Tanlangan chiroqqa zoom qilindi."
        )
    )

    -- OYNA YOPILGANDA
    on CLM_Rollout close do (
        CLM_Dialog = undefined
    )

) -- rollout end

-- ============================================================
-- DIALOG YARATISH
-- ============================================================
if CLM_Dialog != undefined do (
    try (destroyDialog CLM_Dialog) catch()
    CLM_Dialog = undefined
)

createDialog CLM_Rollout \
    style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing) \
    pos:[150,80]
CLM_Dialog = CLM_Rollout

) -- macroScript end
